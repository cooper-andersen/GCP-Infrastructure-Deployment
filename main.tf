provider "google" {
    project = "your-project-id"
    region  = "us-central1"
}

resource "google_compute_instance" "vm_instance" {
    name         = "my-vm"
    machine_type = "e2-micro" // Change machine type to e2-micro
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

resource "google_compute_firewall" "firewall" {
    name    = "allow-https-and-ssh"
    network = "default"

    allow {
        protocol = "tcp"
        ports    = ["443"]
    }

    allow {
        protocol       = "tcp"
        ports          = ["22"]
        source_ranges  = ["10.0.0.0/8"]
    }

    deny {
        protocol       = "tcp"
        ports          = ["0-65535"]
        source_ranges  = ["0.0.0.0/0"]
    }
}

resource "google_compute_http_health_check" "health_check" {
    name               = "wordpress-health-check"
    check_interval_sec = 10
    timeout_sec        = 5
    unhealthy_threshold = 3
    healthy_threshold   = 2
    port               = 80
    request_path       = "/"
}

resource "google_compute_backend_service" "backend_service" {
    name        = "wordpress-backend-service"
    protocol    = "HTTP"
    timeout_sec = 10

    health_checks = [
        google_compute_http_health_check.health_check.self_link
    ]

    backend {
        group = google_compute_instance_group.vm_instance_group.self_link
    }
}

resource "google_compute_instance_group" "vm_instance_group" {
    name        = "wordpress-instance-group"
    description = "Instance group for WordPress VMs"

    named_port {
        name = "http"
        port = 80
    }

    named_port {
        name = "https"
        port = 443
    }

    instance_template = google_compute_instance_template.vm_instance_template.self_link
}

resource "google_compute_instance_template" "vm_instance_template" {
    name        = "wordpress-instance-template"
    description = "Instance template for WordPress VMs"

    properties {
        machine_type = "e2-micro" // Change machine type to e2-micro
        disks {
            boot        = true
            auto_delete = true
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
}

resource "google_compute_target_pool" "target_pool" {
    name        = "wordpress-target-pool"
    description = "Target pool for WordPress VMs"

    instances = [
        google_compute_instance.vm_instance.self_link
    ]
}

resource "google_compute_forwarding_rule" "forwarding_rule" {
    name                  = "wordpress-forwarding-rule"
    description           = "Forwarding rule for WordPress"
    target                = google_compute_target_pool.target_pool.self_link
    port_range            = "80-443"
    ip_protocol           = "TCP"
    load_balancing_scheme = "EXTERNAL"
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