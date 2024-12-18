provider "aws" {
  region = "us-west-2"  # Deine Region
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80  # CPU-Auslastung über 80%

  dimensions = {
    InstanceId = "i-0bbec9f7d6d2b2f3e"  # Die EC2-Instanz-ID, die überwacht wird
  }

  alarm_description = "This alarm triggers when the CPU usage exceeds 80%"
  insufficient_data_actions = []
  ok_actions            = []
  alarm_actions         = ["arn:aws:sns:us-west-2:123456789012:MyTopic"]  # SNS-Benachrichtigung
}

resource "aws_sns_topic" "sns_topic" {
  name = "MyTopic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "spamsachen23@outlook.de"
}
