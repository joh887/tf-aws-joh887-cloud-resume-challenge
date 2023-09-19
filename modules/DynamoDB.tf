variable "DDB_VisitorMetric" {
    default = "VisitorMetric"
}

resource "aws_dynamodb_table" "db" {
    name = "MJ-Metrics"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = var.DDB_VisitorMetric

    attribute {
        name = var.DDB_VisitorMetric
        type = "S"
    }
}

resource "aws_dynamodb_table_item" "db_item" {
    table_name = aws_dynamodb_table.db.name
    hash_key = aws_dynamodb_table.db.hash_key

    item = <<__METRIC__
        {
            "${var.DDB_VisitorMetric}": {"S": "Visitor Metric Counter"},
            "Metric": {"N": "0"}
        }
        __METRIC__
}