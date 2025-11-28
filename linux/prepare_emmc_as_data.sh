# 1. Ver los discos
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

# 2. Desmontar cualquier partición del eMMC
sudo umount /dev/mmcblk0* 2>/dev/null || echo "nada montado en mmcblk0"

# 3. Crear tabla de particiones GPT
sudo parted /dev/mmcblk0 --script mklabel gpt

# 4. Crear UNA partición primaria que ocupe todo
sudo parted /dev/mmcblk0 --script mkpart primary ext4 1MiB 100%

# 5. Formatear la partición en ext4
sudo mkfs.ext4 /dev/mmcblk0p1 -L emmcdata

# 6. Crear el punto de montaje
sudo mkdir -p /data

# 7. Montar la partición
sudo mount /dev/mmcblk0p1 /data

# 8. Probar escritura
echo "hello from eMMC" | sudo tee /data/test.txt
sudo cat /data/test.txt

# 9. Ver estado final del disco
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT /dev/mmcblk0

# 10. Obtener el UUID para fstab
sudo blkid -s UUID -o value /dev/mmcblk0p1
