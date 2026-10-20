# Modelo
# <TIPO_DO_BLOCO> "<TIPO_DO_RECURSO>" "<NOME_LOCAL>" {
#  propriedade1 = "valor"
#  propriedade2 = "valor"
# }

data "aws_availability_zones" "disponiveis" {
  state = "available" # Traz apenas as zonas que estão operacionais no momento
}

# Rede

resource "aws_vpc" "main" {
    cidr_block = "10.1.0.0/16" # O que é isso?

    tags = {
        Name = "main"
    }
}

resource "aws_internet_gateway" "igw" {

    tags = {
        Name = "main"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.1.0.0/16"
    availability_zone = data.aws_availability_zones.disponiveis.names[0]

    tags = {
        Name = "Subnet pública"
    }
}

resource "aws_subnet" "private_subnet_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.1.0.0/16"
    availability_zone = data.aws_availability_zones.disponiveis.names[1]

    tags = {
        Name = "Subnet privada 1"
    }
}

resource "aws_subnet" "private_subnet_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.1.0.0/16"
    availability_zone = data.aws_availability_zones.disponiveis.names[2]

    tags = {
        Name = "Subnet privada 2"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id

    # Qualquer tráfego para fora (0.0.0.0/0) vai pelo IGW
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "Main"
    }
}

resource "aws_route_table_association" "public_assoc" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.main.id
}


# Segurança
resource "aws_security_group" "ec2_sg" {

    name = "lab-ec2-sg"
    description = "Permite tráfego Web vindo da internet"
    vpc_id = aws_vpc.main.id

    # Regras de Entrada (Quem pode ENTRAR na rede/maquina)
    ingress {
        description = "HTTP da Internet"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # De onde vem a conexão (Qualquer IP da internet)
    }

    # Regras de saída (Para onde a máquina pode ENVIAR dados)
    egress {
        # todas as portas (from 0 & to 0)
        from_port = 0 
        to_port = 0
        protocol = "-1" # Todos os protocolos
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "lab-ec2-sg"
    }
}

resource "aws_security_group" "rds_sg" {
    name = "lab-rds-sg"
    description = "Permite PostgreSQL apenas vindo da EC2"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "PostgreSQL apenas da EC2"
        from_port = 5432
        to_port = 5432
        protocol = "tcp"

        # Em vez de IP (cidr_blocks), passa-se o SG da EC2. Para restringir o acesso, não permitindo qualquer máquina na subnet.
        security_groups = [aws_security_group.ec2_sg.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "lab-rds-sg"
    }
}

resource "aws_iam_role" "ec2_role" {
    name = "lab-ec2-execution-role"

    # Políticas de confiança. Comunica à AWS que instancias EC2 podem assumir essa Role.
    assume_role_policy = jsondecode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })

    tags = {
        Name = "lab-ec2-role"
    }
}

# Anexa a poliítica de leitura do ECR (para fazer "docker pull" da imagem)
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
    role = aws_iam_role.ec2_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Anexa a política do Systems Manager (para acessar o terminal via painel AWS)
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Cria o Instance Profile (o "crachá" que a EC2 consegue ler)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "lab-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}


# Repositório

resource "aws_ecr_repository" "api_repo" {
    name = "lab-api-auth"
    image_tag_mutability = "MUTABLE" # Permite sobrescrever a tag "latest"
    force_delete = true # Permite dar 'terraform destroy' mesmo se o repo tiver imagens

    tags = {
        Environment = "Lab"
        Project = "Node-Auth-API"
    }
}

# Política de Ciclo de vida (Limpeza automática)
resource "aws_ecr_lifecycle_policy" "limpeza_imagens_antigas" {
    repository = aws_ecr_repository.api_repo.name
    # Regra em JSON: Mantém apenas as 5 imagens mais recentes para economizar espaço
    policy = jsonencode({
        rules = [
            {
                rulePriority = 1
                description = "Manter apenas as ultimas 5 imagens"
                selection = {
                    tagStatus = "any"
                    countType = "imageCountMoreThan"
                    countNumber = 5
                }
                action = {
                    type = "expire"
                }
            }
        ]
    })
}