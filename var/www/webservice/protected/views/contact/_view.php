<?php
/* @var $this ContactController */
/* @var $data Contact */
?>

<div class="view">

	<b><?php echo CHtml::encode($data->getAttributeLabel('idcontact')); ?>:</b>
	<?php echo CHtml::link(CHtml::encode($data->idcontact), array('view', 'id'=>$data->idcontact)); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('company')); ?>:</b>
	<?php echo CHtml::encode($data->company); ?>
	<br />


</div>