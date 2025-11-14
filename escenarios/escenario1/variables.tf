##############################################
# variables.tf — Variables generales
##############################################

# Nombre del pool de almacenamiento libvirt
variable "libvirt_pool_name" {
  type        = string
  description = "Nombre del pool de almacenamiento libvirt donde se crearán los volúmenes."
  default     = "default"
}

# Directorio asociado al pool de almacenamiento
# (Ruta del sistema de archivos en el host)
variable "libvirt_pool_path" {
  type        = string
  description = "Ruta local del directorio asociado al pool de almacenamiento libvirt."
  default     = "/var/lib/libvirt/images"
}
