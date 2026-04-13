module "network" {
  source = "./modules/vpc"
}

module "app" {
  source     = "./modules/ecs"
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.public_subnets
  sg_id      = module.network.ecs_sg_id
}
