<?php
/* @var $this TicketitemController */
/* @var $model Ticketitem */

$this->breadcrumbs=array(
	'Ticketitems'=>array('index'),
	'Create',
);

$this->menu=array(
	array('label'=>'List Ticketitem', 'url'=>array('index')),
	array('label'=>'Manage Ticketitem', 'url'=>array('admin')),
);
?>

<h1>Create Ticketitem</h1>

<?php $this->renderPartial('_form', array('model'=>$model)); ?>