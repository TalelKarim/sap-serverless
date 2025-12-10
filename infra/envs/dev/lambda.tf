########################
# Lambda: findAllVehicles
########################

module "lambda_find_all_vehicles" {
  source = "../../modules/lambda-basic"

  function_name = "findAllVehicles-${local.env}"
  description   = "Return all vehicles from the DynamoDB table."
  runtime       = "python3.12"
  handler       = "app.handler"

  # Dossier contenant app.py
  source_dir = "${path.root}/../../../app/backend/findAllVehicles"

  timeout     = 10
  memory_size = 256

  environment = {
    VEHICLES_TABLE_NAME = module.vehicles_table.table_name
  }

  tags = local.tags
}

# Droits DynamoDB pour findAllVehicles
resource "aws_iam_role_policy" "lambda_find_all_vehicles_dynamodb" {
  name = "lambda-find-all-vehicles-dynamodb-${local.env}"
  role = module.lambda_find_all_vehicles.role_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:Scan",
          "dynamodb:DescribeTable"
        ],
        Resource = module.vehicles_table.table_arn
      }
    ]
  })
}

########################
# Lambda: findVehicle
########################

module "lambda_find_vehicle" {
  source = "../../modules/lambda-basic"

  function_name = "findVehicle-${local.env}"
  description   = "Return a single vehicle by id from the DynamoDB table."
  runtime       = "python3.12"
  handler       = "app.handler"

  # Dossier contenant app.py
  source_dir = "${path.root}/../../../app/backend/findVehicle"

  timeout     = 10
  memory_size = 256

  environment = {
    VEHICLES_TABLE_NAME = module.vehicles_table.table_name
  }

  tags = local.tags
}

# Droits DynamoDB pour findVehicle
resource "aws_iam_role_policy" "lambda_find_vehicle_dynamodb" {
  name = "lambda-find-vehicle-dynamodb-${local.env}"
  role = module.lambda_find_vehicle.role_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:DescribeTable"
        ],
        Resource = module.vehicles_table.table_arn
      }
    ]
  })
}
