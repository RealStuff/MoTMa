<?php

/**
 *
 * @author wengera
 *
 */
class ITSMController extends Controller {
  
  public function actions() {
  
    return array(
      'SWI_PartnerIncidentCreate_01' => array(
        'class' => 'CWebServiceAction',
        'classMap'=>array(
            'Incident',
            'Contact',
            'Worklog'
        ),
      )
    );
  }
  
  /**
   * @param string $partnerincidentnumber
   * @param string $templatenumber
   * @param Incident
   * @param Contact
   * @param Worklog
   * @return string Ticket Number
   * @soap
   */
  public function newIncident($partnerincidentnumber, $templatenumber, $incident, $contact, $worklog) {
    Yii::log("Create the following TicketID: ");
    
    $ticket = new Ticketitem();
    
    $ticket->partnerincidentnumber = $partnerincidentnumber;
    $now = DateTime::createFromFormat('U.u', microtime(true));
    
    $ticket->incidentnumber = "ITSM0".$now->format("YmdHisu");
    $ticket->templatenumber = $templatenumber;
    $ticket->status = "New";
    
    $incident->isNewRecord = true;
    $incident->save();
    
    $criteria=new CDbCriteria;
    $criteria->compare('company',$contact->company,true);
    
    $newContact = Contact::model()->find($criteria);
    
    if ($newContact === NULL) {
      $contact->isNewRecord = true;
      $contact->save();
    }
    else
      $contact = $newContact;
    
    $ticket->fk_idincident = $incident->idincident;
    $ticket->fk_idcontact = $contact->idcontact;
    
    $ticket->save();
    
    $worklog->isNewRecord = true;
    $worklog->fk_idticketitem = $ticket->idticketitem;
    $worklog->submitdate = $now->format("Y-m-d H:i:s");
    $worklog->save();
    
	  Yii::log("New Ticket Saved...");
  }
}
?>
