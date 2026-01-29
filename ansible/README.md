Run the playbook:
ansible-playbook -i hosts fedora-setup.yml --ask-become-pass

Ping hosts:
ansible all -i hosts -m ping
