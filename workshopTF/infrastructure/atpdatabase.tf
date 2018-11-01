resource "oci_database_autonomous_database" "autonomous_database" {
    #Required
    admin_password = "OpenW0rldD3mo"
    compartment_id = "${var.compartment_ocid}"
    cpu_core_count = "1"
    data_storage_size_in_tbs = "1"
    db_name = "${var.autonomous_database_db_name}"

    #Optional
    display_name = "oowDB"
    license_model = "LICENSE_INCLUDED"
}