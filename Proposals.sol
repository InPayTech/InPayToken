pragma solidity ^0.4.18;
import "./Aliases.sol";

contract Proposals is Aliases {
    struct Comment {
        uint256 id;
        string text;
        address author;
    }

    struct Proposal {
        uint256 id;
        uint status;
        string title;
        string text;
        uint256 timestamp;
        uint256 like;
        uint256 dislike;
        address author;
        mapping(address => bool) likeAddressList;
        mapping(address => bool) dislikeAddressList;
        mapping(uint256 => Comment) commentList;
        uint256 commentsNumber;
    }

    uint256 private MIN_BALANCE_FOR_PROPOSAL = 5000 * COIN;
    uint256 private MIN_BALANCE_FOR_PROPOSAL_LIKE = 1000 * COIN;
    uint256 private MIN_BALANCE_FOR_PROPOSAL_COMMENT = 2500 * COIN;

    uint constant PROPOSAL_NOT_EXIST = 0;
    uint constant PROPOSAL_REMOVED_BY_DEV_SPAM = 1;
    uint constant PROPOSAL_REMOVED_BY_DEV = 2;
    uint constant PROPOSAL_REMOVED_BY_AUTHOR = 3;
    uint constant PROPOSAL_EXIST = 4;
    uint constant PROPOSAL_COMPLETED = 5;
    
    uint constant LIKE = 1;
    uint constant DISLIKE = 2;

    Proposal[] private proposalList;

    event AddProposal(uint256 indexed _proposalId, uint _status, string _title, string _text, address indexed _author);
    event ChangeProposalStatus(uint256 indexed _proposalId, uint _status);
    event AddCommentToProposal(uint256 indexed _proposalId, uint256 _commentId, string _text, address indexed _author);
    event VoteProposal(uint action, uint256 indexed _proposalId, address indexed _voter);

    function addProposal(string title, string text) stopInEmergency public {
        require(!(isEmpty(title) || isEmpty(text) || (balanceOf(msg.sender) < MIN_BALANCE_FOR_PROPOSAL)));
        uint256 len = proposalList.length;
        uint status = PROPOSAL_EXIST;
        proposalList.push(
            Proposal({
                id: len,
                status:status,
                title: title,
                text: text,
                timestamp:now,
                like: 0,
                dislike: 0,
                author:msg.sender,
                commentsNumber: 0
            })
        );
        AddProposal(len, status, title, text, msg.sender);
    }

    function addCommentToProposal(uint256 proposalId, string text) stopInEmergency public {
        require(proposalActionAllowed(proposalId, MIN_BALANCE_FOR_PROPOSAL_COMMENT));
        Proposal storage theProposal = proposalList[proposalId];
        
        uint256 len = theProposal.commentsNumber;

        theProposal.commentList[len] = Comment({
                id:len,
                text:text,
                author:msg.sender
        });
   
        theProposal.commentsNumber++;
        AddCommentToProposal(proposalId, len, text, msg.sender);
    }
    
    function likeProposal(uint256 proposalId) stopInEmergency public {
        voteProposal(LIKE, proposalId);   
    }

    function dislikeProposal(uint256 proposalId) stopInEmergency public {
        voteProposal(DISLIKE, proposalId);   
    }

    function completeProposal(uint256 proposalId) onlyOwner stopInEmergency public {
        require(!proposalRemovedOrCompletedOrNotExist(proposalId));
        uint status = PROPOSAL_COMPLETED;
        proposalList[proposalId].status = status;
        ChangeProposalStatus(proposalId, status);
    }

    function changeProposalStatus(uint256 proposalId, uint status) onlyOwner stopInEmergency public {
        require(proposalExist(proposalId));
        proposalList[proposalId].status = status;
        ChangeProposalStatus(proposalId, status);
    }

    function removeProposal(uint256 proposalId) stopInEmergency public {
        require(isAuthor(proposalId) && (proposalList[proposalId].like == 0) && (proposalList[proposalId].dislike == 0) && !proposalRemovedOrCompletedOrNotExist(proposalId));
        uint status = PROPOSAL_REMOVED_BY_AUTHOR;
        proposalList[proposalId].status = status;
        ChangeProposalStatus(proposalId, status);
    }

    function voteProposal(uint action, uint256 proposalId) private stopInEmergency {
        require(proposalActionAllowed(proposalId, MIN_BALANCE_FOR_PROPOSAL_LIKE));
        Proposal storage theProposal = proposalList[proposalId];
        if (action == LIKE) {
            require(!theProposal.likeAddressList[msg.sender]);
            theProposal.likeAddressList[msg.sender] = true;
            theProposal.like++;
        } else if (action == DISLIKE) {
            require(!theProposal.dislikeAddressList[msg.sender]);
            theProposal.dislikeAddressList[msg.sender] = true;
            theProposal.dislike++;
        }
        VoteProposal(action, proposalId, msg.sender);
    }

    function proposalActionAllowed(uint256 proposalId, uint256 targetBalance) private view returns (bool) {
        return ((!proposalRemovedOrCompletedOrNotExist(proposalId) && (balanceOf(msg.sender) >= targetBalance)));
    }

    function isAuthor(uint256 proposalId) private view returns (bool) {
        return (proposalList[proposalId].author == msg.sender);
    }

    function proposalRemovedOrCompletedOrNotExist(uint256 proposalId) private view returns (bool) {
        return (!proposalExist(proposalId) || (proposalList[proposalId].status != PROPOSAL_EXIST));
    }

    function proposalExist(uint256 proposalId) private view returns (bool) {
        return ((proposalId >= 0) && (proposalId < proposalList.length));
    }

    function getProposal(uint256 _proposalId) public view returns (bool success, uint256 proposalId, uint status, string title, string text, uint256 timestamp, uint256 like, uint256 dislike, uint256 commentsNumber, address author) {
        if (!proposalExist(_proposalId)) {
            (proposalId, status, success) = (_proposalId, PROPOSAL_NOT_EXIST, false);
            return;
        }

        Proposal storage theProposal = proposalList[_proposalId];
        return (true, theProposal.id, theProposal.status, theProposal.title, theProposal.text, theProposal.timestamp, theProposal.like, theProposal.dislike, theProposal.commentsNumber, theProposal.author);
    }
   
    function getProposalComment(uint256 _proposalId, uint256 _commentId) public view returns (bool success, uint256 proposalId, uint256 commentId, string text, address author) {
        if (!proposalExist(_proposalId)) {
            (proposalId, commentId, success) = (_proposalId, _commentId, false);
            return;
        }

        Proposal storage theProposal = proposalList[_proposalId];
        if (!((_commentId >= 0) && (_commentId < theProposal.commentsNumber))) {
            (proposalId, commentId, success) = (_proposalId, _commentId, false);
            return;
        }

        Comment storage theComment = theProposal.commentList[_commentId];

        return (true, _proposalId, theComment.id, theComment.text, theComment.author);
    }
  
    function getProposalsNumber() public view returns (uint256) {
        return proposalList.length;
    }
}
