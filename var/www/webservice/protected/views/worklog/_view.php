<?php
/* @var $this WorklogController */
/* @var $data Worklog */
?>

<div class="view">

	<b><?php echo CHtml::encode($data->getAttributeLabel('idworklog')); ?>:</b>
	<?php echo CHtml::link(CHtml::encode($data->idworklog), array('view', 'id'=>$data->idworklog)); ?>
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

	<b><?php echo CHtml::encode($data->getAttributeLabel('worklogid')); ?>:</b>
	<?php echo CHtml::encode($data->worklogid); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('fk_idticketitem')); ?>:</b>
	<?php echo CHtml::encode($data->fk_idticketitem); ?>
	<br />


</div>