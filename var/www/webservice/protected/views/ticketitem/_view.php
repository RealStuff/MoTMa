<?php
/* @var $this TicketitemController */
/* @var $data Ticketitem */
?>

<div class="view">

	<b><?php echo CHtml::encode($data->getAttributeLabel('idticketitem')); ?>:</b>
	<?php echo CHtml::link(CHtml::encode($data->idticketitem), array('view', 'id'=>$data->idticketitem)); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('fk_idcontact')); ?>:</b>
	<?php echo CHtml::encode($data->fk_idcontact); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('fk_idincident')); ?>:</b>
	<?php echo CHtml::encode($data->fk_idincident); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('partnerincidentnumber')); ?>:</b>
	<?php echo CHtml::encode($data->partnerincidentnumber); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('templatenumber')); ?>:</b>
	<?php echo CHtml::encode($data->templatenumber); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('incidentnumber')); ?>:</b>
	<?php echo CHtml::encode($data->incidentnumber); ?>
	<br />

	<b><?php echo CHtml::encode($data->getAttributeLabel('status')); ?>:</b>
	<?php echo CHtml::encode($data->status); ?>
	<br />
	
	<b>Worklogs:</b><br>
	<?php
	
	foreach ($data->worklogs as $key => $value) {
		?>&emsp;<b><?php echo CHtml::encode($value->idworklog); ?></b> | <?php echo CHtml::encode($value->description);?>
		| <?php echo CHtml::encode($value->submitdate); ?><br><?php
	}
	?>


</div>