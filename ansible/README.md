Run the playbook:
ansible-playbook -i hosts linux-setup.yml

Ping hosts:
ansible all -i hosts -m ping
