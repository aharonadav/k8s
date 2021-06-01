resource "aws_iam_role" "role_with_oidc" {
  name               = var.role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${var.oidc_arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${var.oidc_condition}:sub": "system:serviceaccount:app1:app"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "rbac-s3-policy" {
  role       = "${aws_iam_role.role_with_oidc.name}"
  policy_arn = aws_iam_policy.App1S3AccessPolicy.arn
}