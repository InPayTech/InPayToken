pragma solidity ^0.4.18;
import "./Proposals.sol";

contract Torrents is Proposals { 
    struct Torrent {
        uint256 id;
        string magnet;
        string title;
        string description;
        uint256 timestamp;
        uint256 like;
        uint256 dislike;
        address author;
        mapping(address => bool) likeAddressList;
        mapping(address => bool) dislikeAddressList;
        mapping(uint256 => Comment) commentList;
        uint256 commentsNumber;
    }

    uint256 private MIN_BALANCE_FOR_ADDING_TORRENT = 5000 * COIN;
    uint256 private MIN_BALANCE_FOR_TORRENT_LIKE = 1000 * COIN;
    uint256 private MIN_BALANCE_FOR_TORRENT_COMMENT = 2500 * COIN;

    Torrent[] private torrentList;

    event AddCommentToTorrent(uint256 indexed _torrentId, uint256 _commentId, string _text, address indexed _author);
    event AddTorrent(uint256 indexed _torrentId, string _title, string _description, string _magnet, address indexed _author);    
    event VoteTorrent(uint _action, uint256 indexed _torrentId, address indexed _voter);

    function addTorrent(string title, string description, string magnet) stopInEmergency public {
        require(!(isEmpty(title) || isEmpty(description) || isEmpty(magnet) || (balanceOf(msg.sender) < MIN_BALANCE_FOR_ADDING_TORRENT)));
        uint256 len = torrentList.length;
        torrentList.push(
            Torrent({
                id:len,
                magnet:magnet,
                title:title,
                description:description,
                timestamp:now,
                like:0,
                dislike:0,
                author:msg.sender,
                commentsNumber: 0
            })
        );
        AddTorrent(len, title, description, magnet, msg.sender);
    }

    function addCommentToTorrent(uint256 torrentId, string text) stopInEmergency public {
        require(torrentActionAllowed(torrentId, MIN_BALANCE_FOR_TORRENT_COMMENT));
        Torrent storage theTorrent = torrentList[torrentId];
        
        uint256 len = theTorrent.commentsNumber;

        theTorrent.commentList[len] = Comment({
                id:len,
                text:text,
                author:msg.sender
        });
   
        theTorrent.commentsNumber++;
        AddCommentToTorrent(torrentId, len, text, msg.sender);
    }

    function likeTorrent(uint256 torrentId) stopInEmergency public {
        voteTorrent(LIKE, torrentId);
    }

    function dislikeTorrent(uint256 torrentId) stopInEmergency public {
        voteTorrent(DISLIKE, torrentId);
    }

    function voteTorrent(uint action, uint256 torrentId) private stopInEmergency {
        require (torrentActionAllowed(torrentId, MIN_BALANCE_FOR_TORRENT_LIKE));
        Torrent storage theTorrent = torrentList[torrentId];
        if (action == LIKE) {
            require(!theTorrent.likeAddressList[msg.sender]);
            theTorrent.likeAddressList[msg.sender] = true;
            theTorrent.like++;
        } else if (action == DISLIKE) {
            require(!theTorrent.dislikeAddressList[msg.sender]);
            theTorrent.dislikeAddressList[msg.sender] = true;
            theTorrent.dislike++;
        }
        VoteTorrent(action, torrentId, msg.sender);
    }

    function torrentExist(uint256 torrentId) private view returns (bool) {
        return ((torrentId >= 0) && (torrentId < torrentList.length));
    }

    function torrentActionAllowed(uint256 torrentId, uint256 targetBalance) private view returns (bool) {
        return ((torrentExist(torrentId) && (balanceOf(msg.sender) >= targetBalance)));
    }

    function getTorrent(uint256 _torrentId) public view returns(bool success, uint256 torrentId, string title, string description, string magnet, uint256 timestamp, uint256 like, uint256 dislike, uint256 commentsNumber, address author) {
        if (!torrentExist(_torrentId)) {
            (torrentId, success) = (_torrentId, false);
            return;
        }
        Torrent storage theTorrent = torrentList[_torrentId];
        return (true, theTorrent.id, theTorrent.title, theTorrent.description, theTorrent.magnet, theTorrent.timestamp, theTorrent.like, theTorrent.dislike, theTorrent.commentsNumber, theTorrent.author);
    }
    
    function getTorrentComment(uint256 _torrentId, uint256 _commentId) public view returns (bool success, uint256 torrentId, uint256 commentId, string text, address author) {
        if (!torrentExist(_torrentId)) {
            (torrentId, commentId, success) = (_torrentId, _commentId, false);
            return;
        }
        Torrent storage theTorrent = torrentList[_torrentId];
        if (!((_commentId >= 0) && (_commentId < theTorrent.commentsNumber))) {
            (torrentId, commentId, success) = (_torrentId, _commentId, false);
            return;
        }
        Comment storage theComment = theTorrent.commentList[_commentId];
        return (true, _torrentId, theComment.id, theComment.text, theComment.author);
    }
   
    function getTorrentsNumber() public view returns (uint256) {
        return torrentList.length;
    }
}
