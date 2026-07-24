########################################
# Spot EC2 Instance
########################################

resource "aws_instance" "kind_lab" {

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default_public.ids[0]
  vpc_security_group_ids      = [aws_security_group.kind_lab.id]
  key_name                    = aws_key_pair.kind_lab.key_name
  associate_public_ip_address = var.associate_public_ip

  user_data = file("${path.module}/userdata.sh")

  instance_market_options {

    market_type = "spot"

    spot_options {

      spot_instance_type = var.spot_type

      # instance_interruption_behavior = "stop"

    }

  }

  root_block_device {

    volume_type = "gp3"

    volume_size = var.root_volume_size

    delete_on_termination = true

    encrypted = true

  }

  metadata_options {

    http_endpoint = "enabled"

    http_tokens = "required"

  }

  tags = merge(

    var.common_tags,

    {

      Name = var.instance_name

    }

  )

}