<?php
/* @var $this TicketitemController */
/* @var $model Ticketitem */

$this->breadcrumbs=array(
	'Ticketitems'=>array('index'),
	$model->idticketitem=>array('view','id'=>$model->idticketitem),
	'Update',
);

$this->menu=array(
	array('label'=>'List Ticketitem', 'url'=>array('index')),
	array('label'=>'Create Ticketitem', 'url'=>array('create')),
	array('label'=>'View Ticketitem', 'url'=>array('view', 'id'=>$model->idticketitem)),
	array('label'=>'Manage Ticketitem', 'url'=>array('admin')),
);
?>

<h1>Update Ticketitem <?php echo $model->idticketitem; ?></h1>

<?php $this->renderPartial('_form', array('model'=>$model)); ?>