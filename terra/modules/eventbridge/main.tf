data "template_file" "image_push_event" {
  template = "${file("${path.module}/event.json")}"
}


resource "aws_cloudwatch_event_rule" "image_push" {
  name        = "capture-image-push"
  description = "Capture image push to ECR"

  event_pattern = "${data.template_file.image_push_event.rendered}"
}

output "bridge" {
  value = aws_cloudwatch_event_rule.image_push
}

