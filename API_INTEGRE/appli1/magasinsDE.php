<?php
$magasins = json_decode(file_get_contents("https://projetemerald.fr/API_TEST/API/magasins/".$_GET['notes']));
ob_start();
?>
<h1>Les fiches ayant une note égale à <?= $_GET['notes'];?></h1>
<table class="table">
    <tr>
        <td>ID</td>
        <td>CODE MAGASINS</td>
        <td>MATRICULE CREATION</td>
        <td>DATE DE VISITE</td>
        <td>NOTE</td>
        <td>RAPPORT DE VISITE</td>
        <td>IMAGE</td>
    </tr>
    <?php foreach ($magasins as $magasin) : ?>
        <tr>
            <td><?= $magasin->ID ?></td>
            <td><a href="magasinsCode.php?codecm=<?= $magasin->Code_CM ?>"><?= $magasin->Code_CM ?></a></td>
            <td><?= $magasin->Matricule_creation ?></td>
            <td><?= $magasin->Date_Visite ?></td>
            <td><?= $magasin->NOTE_1 ?></td>
            <td><?= $magasin->Rapport_Visite ?></td>
            <td><img src="<?= $magasin->IMAGE_1 ?>"width="100px;"/></td>
        </tr>
    <?php endforeach; ?>
</table>
<?php
$content = ob_get_clean();
require_once("template.php");