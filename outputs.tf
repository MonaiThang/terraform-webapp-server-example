output "list_all_server_instance_ids" {
  value = aws_instance.webapp[*].id
}

output "server_key_name" {
  value = aws_key_pair.key_pair.key_name
}

output "server_key_file" {
  value = local_file.ssh_key.filename
}

output "server_public_key" {
  value = aws_key_pair.key_pair.public_key
}

output "db_instance_name" {
  value = aws_db_instance.db.id
}

output "db_secret_name" {
  value = aws_secretsmanager_secret.db_connection.name
}