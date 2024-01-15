provider "google" {
    project = "your-project-id"
    region  = "us-central1"
}

resource "google_compute_instance" "vm_instance" {
    name         = "my-vm"
    machine_type = "f1-micro"
    zone         = "us-central1-a"

    boot_disk {
        initialize_params {
            image = "ubuntu-os-cloud/ubuntu-2004-lts"
        }
    }

    network_interface {
        network = "default"
    }

    metadata_startup_script = <<-EOF
        #!/bin/bash
        apt-get update
        apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql

        # Install WordPress
        wget https://wordpress.org/latest.tar.gz
        tar -xzf latest.tar.gz -C /var/www/html/
        chown -R www-data:www-data /var/www/html/wordpress
        chmod -R 755 /var/www/html/wordpress
    EOF
}

resource "google_storage_bucket" "bucket" {
    name     = "my-bucket"
    location = "us-central1"
}

resource "google_sql_database_instance" "database_instance" {
    name             = "my-database"
    region           = "us-central1"
    database_version = "MYSQL_5_7"

    settings {
        tier = "db-f1-micro"
    }
}

output "vm_ip" {
    value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}