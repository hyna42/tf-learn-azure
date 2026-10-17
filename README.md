# Terraform Azure — VM Ubuntu sécurisée (exercice IT-Connect)

Déploie sur Microsoft Azure une VM **Ubuntu 24.04 LTS** joignable en **SSH**, avec un réseau dédié et un accès restreint à une seule IP. Exercice réalisé à partir du cours *L'Infrastructure as Code avec Terraform pour Microsoft Azure* (IT-Connect), adapté aux versions actuelles des outils.

## Architecture

```text
Poste admin (IP publique autorisée)
   │  SSH, port 22
   ▼
IP publique (Standard, statique)
   │
NSG : port 22 autorisé uniquement depuis allowed_ssh_cidr
   │
NIC ──→ Sous-réseau 10.0.1.0/24 (IP privée dynamique)
   │
VM Ubuntu 24.04 LTS (Standard_B1s), authentification par clé SSH
```

Toutes les ressources sont dans un groupe de ressources dédié, dans un VNet `10.0.0.0/16`.

## Structure du projet

```text
.
├── versions.tf               # Versions de Terraform et du provider azurerm
├── providers.tf              # Provider azurerm + enregistrement des Resource Providers
├── locals.tf                 # Tags communs (common_tags)
├── main.tf                   # Ressources : RG, VNet, sous-réseau, IP, NSG, NIC, VM
├── variables.tf              # Déclaration des variables
├── outputs.tf                # IP publique de la VM
├── terraform.tfvars.exemple  # Modèle de valeurs (à copier, sans secrets)
└── .terraform.lock.hcl       # Versions exactes des providers (commité)
```

## Prérequis

| Outil | Version |
|---|---|
| Terraform | >= 1.16.5 |
| Provider azurerm | ~> 5.9.0 |
| Azure CLI | à jour (`az --version`) |
| Abonnement Azure | avec un Service Principal (rôle Contributeur) |
| Clé SSH | ed25519 ou RSA ≥ 2048 bits |

### Service Principal

Terraform s'authentifie avec un **Service Principal** (identité dédiée), et non avec le compte personnel :

1. Portail Azure → **Inscriptions d'application** → nouvelle application.
2. **Certificats & secrets** → nouveau secret client → copier la **Valeur** (affichée une seule fois).
3. **Abonnement** → **Contrôle d'accès (IAM)** → attribuer le rôle **Contributeur** à l'application.

| Valeur Azure | Variable Terraform |
|---|---|
| ID d'application (client) | `ARM_CLIENT_ID` |
| Valeur du secret client | `ARM_CLIENT_SECRET` |
| ID de l'annuaire (locataire) | `ARM_TENANT_ID` |
| ID d'abonnement | `ARM_SUBSCRIPTION_ID` |

### Clé SSH dédiée

```powershell
ssh-keygen -t ed25519 -f $HOME\.ssh\azure-lab -C "azure-lab"
```

Seule la clé **publique** (`.pub`) est transmise à Terraform. La clé privée reste sur le poste et sert à `ssh -i`.

## Configuration

```powershell
Copy-Item terraform.tfvars.exemple terraform.tfvars
```

Puis renseigner `terraform.tfvars`, en particulier :

| Variable | Description |
|---|---|
| `ARM_*` | identifiants du Service Principal |
| `location` | région Azure (voir Limitations) |
| `allowed_ssh_cidr` | ton IP publique en `/32` (`Invoke-RestMethod https://api.ipify.org`) |
| `ssh_public_key` | chemin de la clé **publique** (ex : `~/.ssh/azure-lab.pub`) |

Les autres variables ont des valeurs par défaut (taille de VM, image, plages réseau…).

> `terraform.tfvars`, le state et `tfplan` sont exclus de Git (`.gitignore`) : ils contiennent des secrets.

## Utilisation

```powershell
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

`apply tfplan` applique **exactement** le plan relu, et le refuse s'il a été rendu périmé par une modification du state.

### Connexion à la VM

```powershell
ssh -i ~/.ssh/azure-lab adminuser@$(terraform output -raw vm_public_ip)
```

### Nettoyage (à chaque fin de séance)

```powershell
terraform destroy
terraform state list   # doit être vide
```

## Tags

Toutes les ressources qui le permettent reçoivent les tags définis dans `locals.tf` :

| Tag | Valeur |
|---|---|
| `environment` | `var.environment_tag` (par défaut `dev`) |
| `project` | `tf-learn-azure` |
| `managed_by` | `terraform` (ne pas modifier ces ressources à la main) |

## Sécurité

- **Réseau** : le NSG n'autorise le port 22 que depuis `allowed_ssh_cidr` (une seule IP en `/32`). Tout autre trafic entrant est refusé par défaut.
- **Authentification** : clé SSH uniquement (`disable_password_authentication = true`). Il faut passer **les deux** protections : la bonne IP **et** la bonne clé privée.
- **Secrets** : aucun secret dans le code ni dans Git ; le secret du Service Principal est déclaré `sensitive`.
- **Identité** : Terraform agit sous l'identité du Service Principal, visible dans le journal d'activité Azure.

## Limitations

- **Région `denmarkeast`** : la région `francecentral` refuse les tailles de VM pour cet abonnement gratuit (`NotAvailableForSubscription`). Vérification : `az vm list-skus --location <region> --size Standard_B1 --resource-type virtualMachines -o table`.
- **Quota** : 4 vCPU par région sur le compte gratuit (`az vm list-usage --location <region> -o table`).
- **Provider azurerm 5.x** : il n'enregistre plus automatiquement les Resource Providers Azure ; ils sont déclarés dans `providers.tf` (`resource_providers_to_register`).
- **Image `latest`** : la version exacte de l'image peut changer d'un déploiement à l'autre.
- **IP de l'administrateur** : en cas de changement de réseau, mettre à jour `allowed_ssh_cidr` puis réappliquer.
- **Branches et state** : le state et `terraform.tfvars` ne sont pas versionnés, ils sont donc partagés entre les branches. Faire `terraform destroy` avant de changer de branche.

## Variante Windows

La branche [`feat/windows-vm`](../../tree/feat/windows-vm) remplace la VM Ubuntu par une **VM Windows Server 2025** (Standard_B2s), accessible en **RDP** (port 3389) avec un mot de passe. C'est une variante d'expérimentation, non fusionnée dans `main`.

## Évolutions prévues

- Script PowerShell d'automatisation (`fmt`, `validate`, `tflint`, `plan`, `apply`, `destroy`)
- Configuration au démarrage avec cloud-init (`custom_data`)
- Plusieurs VM avec `for_each`, et coexistence Linux / Windows

## Auteur

Amadou ([@hyna42](https://github.com/hyna42))