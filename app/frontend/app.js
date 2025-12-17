// =======================
// 🔧 CONFIG À ADAPTER
// =======================

// URL de base de ton API HTTP (custom domain ou invoke URL)
const API_BASE_URL = "https://e1uq9useqe.execute-api.eu-west-1.amazonaws.com/dev";

// Config Cognito (remplace avec tes vraies valeurs)
const COGNITO_DOMAIN = "https://talel-dev-auth.auth.eu-west-1.amazoncognito.com"; // ex: https://<domain>.auth.eu-west-1.amazoncognito.com
const COGNITO_CLIENT_ID = "<TON_APP_CLIENT_ID>"; // module.cognito_users.user_pool_client_id
const COGNITO_REDIRECT_URI = "https://app.talelkarimchebbi.com/"; // URL de ton front
const COGNITO_LOGOUT_REDIRECT_URI = "https://app.talelkarimchebbi.com/"; // où renvoyer après logout
const COGNITO_SCOPE = "openid email profile";

// Clés de stockage des tokens
const STORAGE_KEYS = {
  accessToken: "tkc_access_token",
  idToken: "tkc_id_token",
  expiresAt: "tkc_expires_at",
  codeVerifier: "tkc_code_verifier",
};

// =======================
// 🔧 DOM ELEMENTS
// =======================

const vehiclesGrid = document.getElementById("vehiclesGrid");
const listState = document.getElementById("listState");
const refreshBtn = document.getElementById("refreshBtn");
const apiStatus = document.getElementById("apiStatus");

const detailPlaceholder = document.getElementById("detailPlaceholder");
const detailContent = document.getElementById("detailContent");
const detailTitle = document.getElementById("detailTitle");
const detailSubtitle = document.getElementById("detailSubtitle");
const detailId = document.getElementById("detailId");
const detailBrand = document.getElementById("detailBrand");
const detailModel = document.getElementById("detailModel");
const detailYear = document.getElementById("detailYear");
const detailColor = document.getElementById("detailColor");
const detailRawJson = document.getElementById("detailRawJson");

const loginBtn = document.getElementById("loginBtn");
const logoutBtn = document.getElementById("logoutBtn");
const userBadge = document.getElementById("userBadge");

let currentSelection = null;

// =======================
// 🧩 UTILITAIRES GÉNÉRAUX
// =======================

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function clearTokens() {
  sessionStorage.removeItem(STORAGE_KEYS.accessToken);
  sessionStorage.removeItem(STORAGE_KEYS.idToken);
  sessionStorage.removeItem(STORAGE_KEYS.expiresAt);
}

function getStoredAccessToken() {
  const token = sessionStorage.getItem(STORAGE_KEYS.accessToken);
  const expiresAt = parseInt(
    sessionStorage.getItem(STORAGE_KEYS.expiresAt) || "0",
    10
  );
  if (!token || !expiresAt) return null;

  const now = Math.floor(Date.now() / 1000);
  if (now >= expiresAt) {
    clearTokens();
    return null;
  }
  return token;
}

function getStoredIdToken() {
  const token = sessionStorage.getItem(STORAGE_KEYS.idToken);
  const expiresAt = parseInt(
    sessionStorage.getItem(STORAGE_KEYS.expiresAt) || "0",
    10
  );
  if (!token || !expiresAt) return null;
  const now = Math.floor(Date.now() / 1000);
  if (now >= expiresAt) {
    clearTokens();
    return null;
  }
  return token;
}

function storeTokens(tokens) {
  const now = Math.floor(Date.now() / 1000);
  const expiresIn = tokens.expires_in || 3600;
  const expiresAt = now + expiresIn;

  if (tokens.access_token) {
    sessionStorage.setItem(STORAGE_KEYS.accessToken, tokens.access_token);
  }
  if (tokens.id_token) {
    sessionStorage.setItem(STORAGE_KEYS.idToken, tokens.id_token);
  }
  sessionStorage.setItem(STORAGE_KEYS.expiresAt, String(expiresAt));
}

// Décodage simple du payload d’un JWT (pour récupérer email / name)
function decodeJwtPayload(token) {
  try {
    const parts = token.split(".");
    if (parts.length < 2) return null;
    const base64 = parts[1].replace(/-/g, "+").replace(/_/g, "/");
    const padded =
      base64 + "=".repeat((4 - (base64.length % 4)) % 4);
    const json = atob(padded);
    return JSON.parse(json);
  } catch (e) {
    console.error("Failed to decode JWT payload:", e);
    return null;
  }
}

// =======================
// 🔐 PKCE HELPERS
// =======================

function generateRandomString(length = 43) {
  const charset =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~";
  const array = new Uint8Array(length);
  crypto.getRandomValues(array);
  return Array.from(array)
    .map((x) => charset[x % charset.length])
    .join("");
}

function base64UrlEncode(buffer) {
  const bytes = new Uint8Array(buffer);
  let binary = "";
  bytes.forEach((b) => (binary += String.fromCharCode(b)));
  let base64 = btoa(binary);
  return base64
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

async function createCodeChallenge(codeVerifier) {
  const encoder = new TextEncoder();
  const data = encoder.encode(codeVerifier);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return base64UrlEncode(digest);
}

// =======================
// 🔐 AUTH FLOW (LOGIN / LOGOUT)
// =======================

async function startLogin() {
  const codeVerifier = generateRandomString(64);
  sessionStorage.setItem(STORAGE_KEYS.codeVerifier, codeVerifier);
  const codeChallenge = await createCodeChallenge(codeVerifier);

  const params = new URLSearchParams({
    client_id: COGNITO_CLIENT_ID,
    response_type: "code",
    redirect_uri: COGNITO_REDIRECT_URI,
    scope: COGNITO_SCOPE,
    code_challenge_method: "S256",
    code_challenge: codeChallenge,
  });

  window.location.href = `${COGNITO_DOMAIN}/oauth2/authorize?${params.toString()}`;
}

function startLogout() {
  clearTokens();
  const params = new URLSearchParams({
    client_id: COGNITO_CLIENT_ID,
    logout_uri: COGNITO_LOGOUT_REDIRECT_URI,
  });
  window.location.href = `${COGNITO_DOMAIN}/logout?${params.toString()}`;
}

// Gère le callback ?code=... après login
async function handleAuthCallbackIfNeeded() {
  const url = new URL(window.location.href);
  const code = url.searchParams.get("code");
  const error = url.searchParams.get("error");

  if (error) {
    console.error("Cognito auth error:", error);
    // on nettoie l’URL quand même
    url.searchParams.delete("error");
    url.searchParams.delete("error_description");
    window.history.replaceState({}, "", url.pathname);
    return;
  }

  if (!code) return; // pas de callback auth

  const codeVerifier = sessionStorage.getItem(STORAGE_KEYS.codeVerifier);
  sessionStorage.removeItem(STORAGE_KEYS.codeVerifier);

  if (!codeVerifier) {
    console.warn("No PKCE code_verifier found in storage.");
    return;
  }

  try {
    const body = new URLSearchParams({
      grant_type: "authorization_code",
      client_id: COGNITO_CLIENT_ID,
      code,
      redirect_uri: COGNITO_REDIRECT_URI,
      code_verifier: codeVerifier,
    });

    const res = await fetch(`${COGNITO_DOMAIN}/oauth2/token`, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body,
    });

    if (!res.ok) {
      console.error("Token endpoint error:", res.status, await res.text());
      return;
    }

    const tokens = await res.json();
    storeTokens(tokens);

    // Nettoie l’URL (enlève ?code=...)
    url.searchParams.delete("code");
    url.searchParams.delete("state");
    window.history.replaceState({}, "", url.pathname);
  } catch (e) {
    console.error("Error exchanging code for tokens:", e);
  }
}

function isAuthenticated() {
  return !!getStoredAccessToken();
}

// =======================
// 🔐 UI AUTH
// =======================

function updateAuthUI() {
  const accessToken = getStoredAccessToken();
  const idToken = getStoredIdToken();

  if (accessToken) {
    loginBtn.classList.add("hidden");
    logoutBtn.classList.remove("hidden");

    if (idToken) {
      const payload = decodeJwtPayload(idToken);
      const email =
        (payload && (payload.email || payload["cognito:username"])) ||
        "Utilisateur connecté";
      userBadge.textContent = email;
      userBadge.classList.remove("hidden");
    } else {
      userBadge.textContent = "Connecté";
      userBadge.classList.remove("hidden");
    }
  } else {
    loginBtn.classList.remove("hidden");
    logoutBtn.classList.add("hidden");
    userBadge.classList.add("hidden");
  }
}

// =======================
// 🛰 APPELS API AVEC TOKEN
// =======================

async function apiFetch(path, options = {}) {
  const token = getStoredAccessToken();
  const headers = new Headers(options.headers || {});
  if (token) {
    headers.set("Authorization", `Bearer ${token}`);
  }

  const res = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers,
  });

  // Si le token est invalide ou expiré
  if (res.status === 401) {
    clearTokens();
    updateAuthUI();
  }

  return res;
}

// =======================
// 🔎 CHECK API HEALTH
// =======================

async function checkApiHealth() {
  try {
    const res = await apiFetch("/vehicles", { method: "GET" });
    if (res.ok) {
      apiStatus.textContent = "API: OK";
      apiStatus.style.background = "rgba(22, 163, 74, 0.15)";
      apiStatus.style.border = "1px solid rgba(22, 163, 74, 0.8)";
      apiStatus.style.color = "#bbf7d0";
    } else if (res.status === 401) {
      apiStatus.textContent = "API: Auth requise";
      apiStatus.style.background = "rgba(147, 197, 253, 0.08)";
      apiStatus.style.border = "1px solid rgba(96, 165, 250, 0.9)";
      apiStatus.style.color = "#bfdbfe";
    } else {
      apiStatus.textContent = `API: ${res.status}`;
      apiStatus.style.background = "rgba(248, 113, 113, 0.15)";
      apiStatus.style.border = "1px solid rgba(248, 113, 113, 0.8)";
      apiStatus.style.color = "#fecaca";
    }
  } catch (err) {
    console.error("API health check failed:", err);
    apiStatus.textContent = "API: unreachable";
    apiStatus.style.background = "rgba(248, 113, 113, 0.15)";
    apiStatus.style.border = "1px solid rgba(248, 113, 113, 0.8)";
    apiStatus.style.color = "#fecaca";
  }
}

// =======================
// 🚗 LOGIQUE MÉTIER VEHICLES
// =======================

async function fetchVehicles() {
  if (!isAuthenticated()) {
    listState.textContent = "Connecte-toi pour voir la liste des véhicules.";
    vehiclesGrid.innerHTML = "";
    clearDetail();
    return;
  }

  listState.textContent = "Chargement des véhicules…";
  vehiclesGrid.innerHTML = "";
  currentSelection = null;
  clearDetail();

  try {
    const res = await apiFetch("/vehicles", { method: "GET" });
    if (res.status === 401) {
      listState.textContent = "Session expirée ou non authentifiée.";
      return;
    }
    if (!res.ok) {
      listState.textContent = `Erreur API: ${res.status}`;
      return;
    }

    const data = await res.json();
    const items = Array.isArray(data.items) ? data.items : [];

    if (items.length === 0) {
      listState.textContent = "Aucun véhicule trouvé.";
      return;
    }

    listState.textContent = `${items.length} véhicule(s) trouvé(s).`;
    renderVehicles(items);
  } catch (err) {
    console.error("Error fetching vehicles:", err);
    listState.textContent = "Erreur réseau lors du chargement des véhicules.";
  }
}

function renderVehicles(items) {
  vehiclesGrid.innerHTML = "";

  items.forEach((v) => {
    const card = document.createElement("article");
    card.className = "vehicle-card";
    card.dataset.vehicleId = v.id;

    const avatar = document.createElement("div");
    avatar.className = "vehicle-avatar";
    const initials = `${(v.brand || "?")[0] || "?"}${
      (v.model || "")[0] || ""
    }`;
    avatar.textContent = initials.toUpperCase();

    const main = document.createElement("div");
    main.className = "vehicle-main";

    const title = document.createElement("h3");
    title.className = "vehicle-title";
    title.textContent = `${v.brand || "Marque inconnue"} ${
      v.model || ""
    }`.trim();

    const sub = document.createElement("p");
    sub.className = "vehicle-sub";
    const year = v.year != null ? `${v.year}` : "N/A";
    const color = v.color || "couleur inconnue";
    sub.textContent = `Année ${year} · ${color}`;

    main.appendChild(title);
    main.appendChild(sub);

    const label = document.createElement("span");
    label.className = "vehicle-label";
    label.textContent = v.id || "ID inconnu";

    card.appendChild(avatar);
    card.appendChild(main);
    card.appendChild(label);

    card.addEventListener("click", () => {
      selectCard(card);
      loadVehicleDetail(v.id);
    });

    vehiclesGrid.appendChild(card);
  });
}

function selectCard(card) {
  if (currentSelection) {
    currentSelection.classList.remove("selected");
  }
  card.classList.add("selected");
  currentSelection = card;
}

function clearDetail() {
  detailContent.classList.add("hidden");
  detailPlaceholder.classList.remove("hidden");
}

// Fetch detail by id
async function loadVehicleDetail(id) {
  if (!id) return;

  if (!isAuthenticated()) {
    detailPlaceholder.textContent = "Connecte-toi pour voir le détail.";
    detailPlaceholder.classList.remove("hidden");
    detailContent.classList.add("hidden");
    return;
  }

  detailPlaceholder.textContent = "Chargement du détail…";
  detailPlaceholder.classList.remove("hidden");
  detailContent.classList.add("hidden");

  try {
    const res = await apiFetch(`/vehicles/${encodeURIComponent(id)}`, {
      method: "GET",
    });

    if (res.status === 401) {
      detailPlaceholder.textContent = "Non authentifié ou session expirée.";
      return;
    }
    if (res.status === 404) {
      detailPlaceholder.textContent = "Véhicule introuvable.";
      return;
    }
    if (!res.ok) {
      detailPlaceholder.textContent = `Erreur API: ${res.status}`;
      return;
    }

    const item = await res.json();
    fillDetail(item);
  } catch (err) {
    console.error("Error fetching vehicle detail:", err);
    detailPlaceholder.textContent =
      "Erreur réseau lors du chargement du détail.";
  }
}

function fillDetail(v) {
  detailPlaceholder.classList.add("hidden");
  detailContent.classList.remove("hidden");

  detailTitle.textContent = `${v.brand || "Marque inconnue"} ${
    v.model || ""
  }`.trim();
  detailSubtitle.textContent = `Véhicule stocké dans DynamoDB – ID ${
    v.id || "?"
  }`;

  detailId.textContent = v.id || "—";
  detailBrand.textContent = v.brand || "—";
  detailModel.textContent = v.model || "—";
  detailYear.textContent = v.year != null ? v.year : "—";
  detailColor.textContent = v.color || "—";

  detailRawJson.textContent = JSON.stringify(v, null, 2);
}

// =======================
// 🚀 INIT
// =======================

document.addEventListener("DOMContentLoaded", async () => {
  // 1) Traite un éventuel callback Cognito (?code=...)
  await handleAuthCallbackIfNeeded();

  // 2) Met à jour l’UI d’auth
  updateAuthUI();

  // 3) Bind des boutons
  loginBtn.addEventListener("click", () => {
    startLogin();
  });

  logoutBtn.addEventListener("click", () => {
    startLogout();
  });

  refreshBtn.addEventListener("click", () => {
    fetchVehicles();
  });

  // 4) Si on est loggué → check API + charge la liste
  if (isAuthenticated()) {
    checkApiHealth();
    fetchVehicles();
  } else {
    apiStatus.textContent = "API: Auth requise";
    listState.textContent = "Connecte-toi pour voir les véhicules.";
  }
});
