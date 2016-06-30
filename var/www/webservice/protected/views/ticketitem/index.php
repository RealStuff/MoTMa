<?php
/* @var $this TicketitemController */
/* @var $dataProvider CActiveDataProvider */

$this->breadcrumbs=array(
	'Ticketitems',
);

$this->menu=array(
	array('label'=>'Create Ticketitem', 'url'=>array('create')),
	array('label'=>'Manage Ticketitem', 'url'=>array('admin')),
);
?>

<h1>Ticketitems</h1>

<?php $this->widget('zii.widgets.CListView', array(
	'dataProvider'=>$dataProvider,
	'itemView'=>'_view',
)); ?>
