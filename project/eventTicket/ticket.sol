// SPDX-License-Identifier: MIT




pragma solidity ^0.8.26;




contract EventContract {
struct Event{
address organizer;
string eventName;
uint date;
string venue;//
uint ticketPrice;//
uint ticketCount;
uint ticketleft;
}

mapping(uint=>Event) public events;
mapping(address=>mapping(uint=>uint)) public tickets;
uint public nextId;
function createEvent(string memory _eventName,
uint _date,
string memory _venue,
uint _ticketPrice,
uint _ticketCount) external {
require(_date>block.timestamp, "event is experied already");
require(_ticketCount>0, "have atleast one ticket");

events[nextId] = Event(msg.sender, _eventName, _date,  _venue,  _ticketPrice, _ticketCount,_ticketCount);
nextId++;

}



function buyTicket(uint id, uint noticket) external payable {
require(events[id].date !=0,"this events dosnt exist");
require(block.timestamp<events[id].date, "Event expires");
Event storage _event = events[id];///it is struct type so use storage
require(msg.value ==(_event.ticketPrice*noticket), "ether is not enough");
require(_event.ticketleft>=noticket,"not enough tickets are remain");
_event.ticketleft -= noticket;
tickets[msg.sender][id]+=noticket;
}




// lets make transfer ticket function so that user send ticket to his gf
function transferTicket(uint id, uint quantity, address to) external{
    require(events[id].date !=0,"this events dosnt exist");
    require(block.timestamp<events[id].date, "Event expires");
    require(tickets[msg.sender][id]>=quantity,"you donot have enough tickets");
    tickets[msg.sender][id] -=quantity;
    tickets[to][id] += quantity;
}







}
