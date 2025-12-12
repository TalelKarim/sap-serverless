// 🔧 À adapter si ton URL change
const API_BASE_URL = "https://fth94anp4l.execute-api.eu-west-1.amazonaws.com/dev";

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

let currentSelection = null;

// Utility: small sleep (for nicer UX if needed)
function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function checkApiHealth() {
  try {
    const res = await fetch(`${API_BASE_URL}/vehicles`, { method: "GET" });
    if (res.ok) {
      apiStatus.textContent = "API: OK";
      apiStatus.style.background = "rgba(22, 163, 74, 0.15)";
      apiStatus.style.border = "1px solid rgba(22, 163, 74, 0.8)";
      apiStatus.style.color = "#bbf7d0";
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

async function fetchVehicles() {
  listState.textContent = "Chargement des véhicules…";
  vehiclesGrid.innerHTML = "";
  currentSelection = null;
  clearDetail();

  try {
    const res = await fetch(`${API_BASE_URL}/vehicles`);
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
    const initials = `${(v.brand || "?")[0] || "?"}${(v.model || "")[0] || ""}`;
    avatar.textContent = initials.toUpperCase();

    const main = document.createElement("div");
    main.className = "vehicle-main";

    const title = document.createElement("h3");
    title.className = "vehicle-title";
    title.textContent = `${v.brand || "Marque inconnue"} ${v.model || ""}`.trim();

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

  detailPlaceholder.textContent = "Chargement du détail…";
  detailPlaceholder.classList.remove("hidden");
  detailContent.classList.add("hidden");

  try {
    const res = await fetch(`${API_BASE_URL}/vehicles/${encodeURIComponent(id)}`);
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
    detailPlaceholder.textContent = "Erreur réseau lors du chargement du détail.";
  }
}

function fillDetail(v) {
  detailPlaceholder.classList.add("hidden");
  detailContent.classList.remove("hidden");

  detailTitle.textContent = `${v.brand || "Marque inconnue"} ${v.model || ""}`.trim();
  detailSubtitle.textContent = `Véhicule stocké dans DynamoDB – ID ${v.id || "?"}`;

  detailId.textContent = v.id || "—";
  detailBrand.textContent = v.brand || "—";
  detailModel.textContent = v.model || "—";
  detailYear.textContent = v.year != null ? v.year : "—";
  detailColor.textContent = v.color || "—";

  detailRawJson.textContent = JSON.stringify(v, null, 2);
}

/* Init */

document.addEventListener("DOMContentLoaded", async () => {
  // Vérifie l'état de l'API en fond (sans bloquer)
  checkApiHealth();
  // Charge la liste immédiatement
  fetchVehicles();
});

refreshBtn.addEventListener("click", () => {
  fetchVehicles();
});
