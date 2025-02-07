module "sync-user" {
  #checkov:skip=CKV_AWS_273:We really need a user for this setup
  name                  = "SCSyncUser"
  source                = "github.com/schubergphilis/terraform-aws-mcaf-user?ref=v0.4.0"
  create_iam_access_key = var.create_access_keys
  create_policy         = true
  kms_key_id            = var.kms_key_arn
  policy                = aws_iam_policy.sqs_policy.policy
  tags                  = var.tags

  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSConfigUserAccess",
    "arn:aws:iam::aws:policy/AWSServiceCatalogAdminReadOnlyAccess"
  ]
}

//Create custom policies
resource "aws_iam_policy" "sqs_policy" {
  name        = "sqs_policy"
  description = "sqs_policy"
  policy      = data.aws_iam_policy_document.sqs_policy.json
}

data "aws_iam_policy_document" "sqs_policy" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch"
    ]

    resources = [aws_sqs_queue.servicenow_queue.arn]
  }
}
