pragma solidity ^0.4.8;
import "Alias.sol";

contract Voting is Alias {
  struct Proposal {
    uint256 id;
    int status;
    string title;
    string text;
    uint256 timestamp;
    uint256 vote;
    address author;
    mapping(address => bool) voters;
  }

  uint MIN_BALANCE_FOR_VOTE = 1000 * COIN;
  uint MIN_BALANCE_FOR_PROPOSAL = 5000 * COIN;

  int PROPOSAL_REMOVED_BY_DEV_SPAM = -3;
  int PROPOSAL_REMOVED_BY_DEV = -2;
  int PROPOSAL_REMOVED_BY_AUTHOR = -1;
  int PROPOSAL_NOT_EXIST = 0;
  int PROPOSAL_EXIST = 1;
  int PROPOSAL_COMPLETED = 2;

  Proposal[] proposalsList;

  event MakeProposal(uint256 _id, int _status, string _title, string _text, uint256 _timestamp, address _author);
  event VoteProposal(uint256 _id, address _address);
  event ChangeProposalStatus(uint256 _id, int _status);

  function Voting() { }

  function makeProposal(string title, string text) {
    if(isEmpty(title) || isEmpty(text) || (balanceOf(msg.sender) < MIN_BALANCE_FOR_PROPOSAL)) throw;
    uint256 len = proposalsList.length;
    int status = PROPOSAL_EXIST;
    proposalsList.push(Proposal({id: len, status:status, title: title, text: text, timestamp:now, vote: 1, author:msg.sender}));
    MakeProposal(len, status, title, text, now, msg.sender);
  }

  function voteForProposal(uint256 id) {
      if(proposalRemovedOrCompletedOrNotExist(id) || (balanceOf(msg.sender) < MIN_BALANCE_FOR_VOTE)) throw;

      Proposal theProposal = proposalsList[id];
      if((isAuthor(id)) || (theProposal.voters[msg.sender])) throw;

      theProposal.status = PROPOSAL_EXIST;
      theProposal.voters[msg.sender] = true;
      theProposal.vote++;
      VoteProposal(id, msg.sender);
  }

  function completeProposal(uint256 id) {
    if(!isDev() || (proposalRemovedOrCompletedOrNotExist(id))) throw;
    int status = PROPOSAL_COMPLETED;
    proposalsList[id].status = status;
    ChangeProposalStatus(id, status);
  }

  function isAuthor(uint256 _id) private returns(bool) {
    return (proposalsList[_id].author == msg.sender);
  }

  function isDev() private returns(bool) {
    return (devAddress == msg.sender);
  }

  function changeProposalStatus(uint256 id, int status) {
    if(!isDev() || (id < 0)) throw;
    proposalsList[id].status = status;
    ChangeProposalStatus(id, status);
  }

  function removeProposal(uint256 id) {
    if(proposalRemovedOrCompletedOrNotExist(id)) throw;
    if(!isAuthor(id) || (proposalsList[id].vote > 1)) throw;
    int status = PROPOSAL_REMOVED_BY_AUTHOR;
    proposalsList[id].status = status;
    ChangeProposalStatus(id, status);
  }

  function proposalRemovedOrCompletedOrNotExist(uint256 _id) private returns (bool) {
    return (proposalNotExist(_id) || (proposalsList[_id].status != PROPOSAL_EXIST));
  }

  function proposalNotExist(uint256 _id) private returns (bool) {
    return ((_id < 0) || (_id >= proposalsList.length));
  }

  function getProposalsNumber() constant returns (uint256) {
    return proposalsList.length;
  }

  function getProposal(uint256 _id) constant returns (uint256 id, int status, string title, string text, uint256 timestamp, uint256 vote, address author) {
    if(proposalNotExist(_id)) {
        status = PROPOSAL_NOT_EXIST;
        return;
    }

    Proposal theProposal = proposalsList[_id];
    return (theProposal.id, theProposal.status, theProposal.title, theProposal.text, theProposal.timestamp, theProposal.vote, theProposal.author);
  }
}
