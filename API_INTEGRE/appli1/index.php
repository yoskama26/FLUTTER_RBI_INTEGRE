<?php
ob_start();
?>
<h1>Integré Rubis</h1>
<?php
$content = ob_get_clean();
require_once("template.php");