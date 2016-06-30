<?php
/* @var $this IncidentController */
/* @var $model Incident */

$this->breadcrumbs=array(
	'Incidents'=>array('index'),
	$model->idincident=>array('view','id'=>$model->idincident),
	'Update',
);

$this->menu=array(
	array('label'=>'List Incident', 'url'=>array('index')),
	array('label'=>'Create Incident', 'url'=>array('create')),
	array('label'=>'View Incident', 'url'=>array('view', 'id'=>$model->idincident)),
	array('label'=>'Manage Incident', 'url'=>array('admin')),
);
?>

<h1>Update Incident <?php echo $model->idincident; ?></h1>

<?php $this->renderPartial('_form', array('model'=>$model)); ?>