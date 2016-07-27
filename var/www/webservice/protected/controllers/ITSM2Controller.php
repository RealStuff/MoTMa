<?php

/**
 *
 * @author wengera
 *
 */
class ITSM2Controller extends Controller {
  
  public function actions() {
  
    return array(
      'SWI_PartnerIncidentResponse_02' => array(
        'class' => 'CWebServiceAction',
        'classMap'=>array(
          'Incident',
          'Worklog'
        ),
      )
    );
  }
  
  /**
   * @param string $partnerincidentnumber
   * @param string $templatenumber
   * @param string $type
   * @param Incident
   * @param Worklog
   * @soap
   */
  public function Update($partnerincidentnumber, $incidentnumber, $type, $incident, $worklog) {

    $criteria = new CDbCriteria();
    $criteria->compare('partnerincidentnumber', $partnerincidentnumber, false);
    $now = DateTime::createFromFormat('U.u', microtime(true));

    $ticket = Ticketitem::model()->find($criteria);
    if ($ticket === NULL)
      return 0;
    
    if ($type == "ClosedBySystem" )
      $ticket->status = "Resolved";
    
    $ticket->fkIdincident = $incident;
    $ticket->fkIdincident->save();
    
    $ticket->save();

    $worklog->isNewRecord = true;
    $worklog->fk_idticketitem = $ticket->idticketitem;
    $worklog->submitdate = $now->format("Y-m-d H:i:s");
    $worklog->save();
    
	  Yii::log("New Ticket Saved...");
  }
}
?>
