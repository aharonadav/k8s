resource "aws_iam_policy" "policy" {
  name        = "ecr_eks_policy"
  path        = "/"
  description = "EKS ECR policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = "eks-dev-Worker-Role"
  policy_arn = "arn:aws:iam::889397717348:policy/ecr_eks_policy"
}