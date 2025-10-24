# Deploy with Ansible

## Cấu trúc thư mục ansible triển khai dự án frontend

``` bash
ansible-frontend/
├── inventory/
│   └── hosts.ini
├── playbooks/
│   └── deploy_frontend.yml
└── ansible.cfg
```

## Cài đặt ansible trên server điều khiển (10.1.0.13)

### 1. 

``` bash
sudo apt update
sudo apt install ansible -y
ansible --version
ssh-keygen -t ed25519 -C "ansible-controller"
ssh-copy-id devops@10.1.0.23
```

### 2.

``` bash
### File inventory/hosts.ini
[defaults]
inventory = inventory/hosts.ini
host_key_checking = False
```

``` bash
### File ansible.cfg
[onprem-frontend]
10.1.0.23 ansible_user=devops ansible_ssh_private_key_file=~/.ssh/id_rsa
```

``` yaml
### File playbooks/deploy_frontend.yml
- name: Build and deploy frontend to on-premise Nginx server
  hosts: onprem-frontend
  become: yes

  vars:
    project_dir: /home/dev/project/Backend-FoodWeb # Thư mục của dự án Frontend
    build_dir: "{{ project_dir }}/build"
    remote_deploy_dir: /var/www/html

  tasks:
    # 1. Cài đặt Node.js & Nginx
    - name: Ensure APT packages are updated
      apt:
        update_cache: yes

    - name: Install and Nginx
      apt:
        name: nginx
        state: present

    # 2. Cài đặt dependency và build project
    - name: Install Node.js dependencies
      args:
        chdir: "{{ project_dir }}"
      shell: npm install

    - name: Build frontend project
      args:
        chdir: "{{ project_dir }}"
      shell: npm run build

    # 3. Deploy file build ra Nginx web root
    - name: Clear old files in Nginx html folder
      file:
        path: "{{ remote_deploy_dir }}"
        state: absent

    - name: Recreate Nginx web root folder
      file:
        path: "{{ remote_deploy_dir }}"
        state: directory
        owner: www-data
        group: www-data
        mode: "0755"

    - name: Copy build output to Nginx web root
      copy:
        src: "{{ build_dir }}/"
        dest: "{{ remote_deploy_dir }}/"
        owner: www-data
        group: www-data
        mode: "0755"
        remote_src: yes

    - name: Create Nginx config for frontend
      copy:
        dest: /etc/nginx/sites-available/frontend.conf
        content: |
          server {
              listen 80;
              server_name testing-domain.greenglobal.com.vn;
              root /var/www/html;
              index index.html;
              location / {
                  try_files $uri /index.html;
              }
          }

    - name: Enable Nginx site
      file:
        src: /etc/nginx/sites-available/frontend.conf
        dest: /etc/nginx/sites-enabled/frontend.conf
        state: link
        force: yes

    - name: Remove default site
      file:
        path: /etc/nginx/sites-enabled/default
        state: absent

    # 5. Restart Nginx
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

### Run

``` bash
ansible-playbook playbooks/deploy_frontend.yml --ask-become-pass
```

## Trên server triển khai dự án (10.1.0.23)

``` bash
sudo adduser devops
sudo usermod -aG sudo devops
```