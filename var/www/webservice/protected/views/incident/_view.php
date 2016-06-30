<?php
/* @var $this IncidentController */
/* @var $data Incident */
?>

<div class="view">

	<b><?php echo CHtml::encode($data->getAttributeLabel('idincident')); ?>:</b>
	<?php echo CHtml::link(CHtml::encode($data->idincident), array('view', 'id'=>$data->idincident)); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('priority')); ?>:</b>
	<?php echo CHtml::encode($data->priority); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('impact')); ?>:</b>
	<?php echo CHtml::encode($data->impact); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('urgency')); ?>:</b>
	<?php echo CHtml::encode($data->urgency); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('description')); ?>:</b>
	<?php echo CHtml::encode($data->description); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('detail')); ?>:</b>
	<?php echo CHtml::encode($data->detail); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('submitdate')); ?>:</b>
	<?php echo CHtml::encode($data->submitdate); ?>
	<br />

	<?php /*
	<b><?php echo CHtml::encode($data->getAttributeLabel('targetresolutiondate')); ?>:</b>
	<?php echo CHtml::encode($data->targetresolutiondate); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('customer')); ?>:</b>
	<?php echo CHtml::encode($data->customer); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('productname')); ?>:</b>
	<?php echo CHtml::encode($data->productname); ?>
	<br />

	*/ ?>

</div>