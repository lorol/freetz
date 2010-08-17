#! /bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi --id=firmware_update
cgi_begin '$(lang de:"Firmware-Update" en:"Firmware update")'

cat << EOF
<script type="text/javascript">
function CheckInput(form) {
	file_selector=form.elements[0];
	radio_stop=form.elements[1];
	radio_semistop=form.elements[2];
	radio_nostop=form.elements[3];
	downgrade=form.elements[4];

	if (file_selector.value=="") {
		alert("$(lang de:"Keine Firmware-Datei angegeben!" en:"No firmware file provided!")");
		return false;
	}
	if (radio_stop.checked) {
		file_selector.name="stop_avm";
	}
	else if (radio_semistop.checked) {
		file_selector.name="semistop_avm";
	}
	else {
		file_selector.name="nostop_avm";
	}
	if (downgrade.checked) {
		file_selector.name += "/downgrade";
	}

	return true;
}
</script>

<h1>$(lang de:"Firmware hochladen" en:"Upload firmware")</h1>

<p>$(lang
    de:"Im ersten Schritt ist ein Firmware-Image zum Upload auszuw&auml;hlen.
Dieses Image wird auf die Box geladen und dort entpackt. Anschlie&szlig;end
wird <i>/var/install</i> aufgerufen. Falls das erfolgreich ist, kann das Update
mit einem Klick auf den Button &quot;Neustart&quot; ausgef&uuml;hrt werden. Bei
Auswahl des Men&uuml;punkts f&uuml;r Remote-Update wird die Box nach 30 Sekunden
automatisch neu gestartet."
    en:"First you are encouraged to select a firmware image for uploading. This image
will be loaded to and extracted on the box. Subsequently, <i>/var/install</i>
will be called. If successful, the update can be started by clicking the button
&quot;Reboot&quot;. If &quot;remote firmware update&quot; is selected, the box restarts
automatically after 30 seconds."
)</p>

<form action="do_firmware.cgi" method="POST" enctype="multipart/form-data" onsubmit="return CheckInput(document.forms[0]);">
	<p>
	$(lang de:"Firmware-Image" en:"Firmware image")
	<input type=file size=50 id="fw_file">
	</p>
	<p>
	<input type="radio" name="do_prepare" value="stop_avm">
	$(lang de:"AVM-Dienste stoppen (bei Speichermangel)" en:"Stop AVM services (less memory available)")<br>
	<input type="radio" name="do_prepare" value="semistop_avm">
	$(lang de:"Einen Teil der AVM-Dienste stoppen (bei Remote-Update)" en:"Stop some of the AVM services (remote firmware update)")<br>
	<input type="radio" name="do_prepare" value="nostop_avm" checked>
	$(lang de:"AVM-Dienste nicht stoppen (bei gen&uuml;gend Speicher bzw. Pseudo-Update ohne Reboot)" en:"Do not stop any AVM services (sufficient memory available or pseudo update without reboot)")
	</p>
	<p>
	<input type="checkbox" name="downgrade" value="yes">
	$(lang de:"Downgrade auf &auml;ltere Version zulassen" en:"Allow downgrade to older version")
	</p>
	<div class="btn"><input type=submit value="$(lang de:"Firmware hochladen" en:"Upload firmware")" style="width:200px"></div>
	<div style="clear: both; text-align: right;"><a href="external.cgi">$(lang de:"external-Datei hochladen (optional)" en:"upload external file (optional)")</a></div>
</form>

EOF

cgi_end
