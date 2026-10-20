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