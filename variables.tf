# Modelo
# variable "nome_da_variavel" {
#   type        = tipo_do_dado
#   description = "Uma breve explicação de para que serve essa variável"
#   default     = "valor_padrao_opcional"
#   sensitive   = false # opcional, útil para senhas
# }

variable "tipo_instancia" {
    type = string
    description = "Define qual o tamanho da EC2"
    default = "t3.micro"
}

variable "db_name" {
  type        = string
  description = "Nome do banco de dados PostgreSQL"
  default     = "lab_api_db"
}

variable "db_username" {
  type        = string
  description = "Usuário mestre do RDS"
  default     = "postgres"
}

variable "db_password" {
  type        = string
  description = "Senha mestre do RDS"
  sensitive   = true # Impede que a senha apareça em texto puro nos logs do terraform apply
}