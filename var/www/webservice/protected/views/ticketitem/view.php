<?php
/* @var $this TicketitemController */
/* @var $model Ticketitem */

$this->breadcrumbs=array(
	'Ticketitems'=>array('index'),
	$model->idticketitem,
);

$this->menu=array(
	array('label'=>'List Ticketitem', 'url'=>array('index')),
	array('label'=>'Create Ticketitem', 'url'=>array('create')),
	array('label'=>'Update Ticketitem', 'url'=>array('update', 'id'=>$model->idticketitem)),
	array('label'=>'Delete Ticketitem', 'url'=>'#', 'linkOptions'=>array('submit'=>array('delete','id'=>$model->idticketitem),'confirm'=>'Are you sure you want to delete this item?')),
	array('label'=>'Manage Ticketitem', 'url'=>array('admin')),
);
?>

<h1>View Ticketitem #<?php echo $model->idticketitem; ?></h1>

<?php $this->widget('zii.widgets.CDetailView', array(
	'data'=>$model,
	'attributes'=>array(
		'idticketitem',
		'fk_idcontact',
		'fk_idincident',
		'partnerincidentnumber',
		'templatenumber',
		'incidentnumber',
		'status',
	),
)); ?>
