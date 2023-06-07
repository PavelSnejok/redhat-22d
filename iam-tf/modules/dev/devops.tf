resource "aws_iam_role" "devops" {
  name = var.devops_role

  # ...omitted...
}

resource "aws_iam_policy" "full_permission" {
  name        = var.devops_policy
  
  # ...omitted...
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.devops.name
  policy_arn = aws_iam_policy.full_permission.arn
}
