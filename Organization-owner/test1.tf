resource "aws_key_pair" "dove-key" {
  key_name   = "boma-key"
  public_key = file("boma-key.pub")
}

resource "aws_instance" "dove-inst" {
  ami                    = var.AMIS[var.REGION]
  instance_type          = "t3.micro"
  availability_zone      = var.ZONE1
  key_name               = aws_key_pair.dove-key.key_name
  vpc_security_group_ids = [var.SG]
  tags = {
    Name    = "Dove-Instance"
    Project = "Dove"
  }

  connection {
    user        = var.USER
    private_key = file("boma-key")
    host        = self.public_ip
  }
  provisioner "file" {
    source      = "cbn.sh"
    destination = "/tmp/cbn.sh"
  }

  provisioner "remote-exec" {

    inline = [
      "chmod +x /tmp/cbn.sh",
      "ls -l /tmp",
      "pwd",
      "sudo /tmp/cbn.sh"
    ]
  }
}

output "PublicIP" {
  value = aws_instance.dove-inst.public_ip
}

output "PrivateIP" {
  value = aws_instance.dove-inst.private_ip
}

resource "null_resource" "write_output" {
  provisioner "local-exec" {
    command = "echo ${aws_instance.dove-inst.public_ip} > output.txt"
  }
}
  # connection {
  #   user        = var.USER
  #   private_key = file("boma-key")
  #   host        = self.public_ip
  # }


