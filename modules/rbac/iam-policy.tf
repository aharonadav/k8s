data "aws_iam_policy_document" "App1S3AccessPolicy" {
  statement {
    sid    = "VisualEditor0"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "App1S3AccessPolicy" {
  name = "App1S3AccessPolicy"

  policy = data.aws_iam_policy_document.App1S3AccessPolicy.json
}