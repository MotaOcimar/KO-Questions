pragma solidity 0.8.10;

contract main
{
    mapping(address => User) private login;

    struct User
    {
        string nickname;
        uint[] questionsAsked;
        uint[] questionsAnswered;
    }

    struct Question
    {
        uint id;
        address author;
        string text;
        address[] upVoters;
        address[] downVoters;
        Answer[] answers;
    }

    struct Answer
    {
        uint id;
        address author;
        string text;
        address[] upVoters;
        address[] downVoters;
    }

    struct Pack
    {
        uint id;
        string text;
        int repupation;
    }

    Question[] private questions;
    uint numQuestions;
    Question auxQuestion;
    Answer auxAnswer;

    function makeQuestion(string memory _text) public
    {
        auxQuestion.id = numQuestions;
        auxQuestion.author = msg.sender;
        auxQuestion.text = _text;
        questions.push(auxQuestion);
        User storage user = login[msg.sender];
        user.questionsAsked.push(numQuestions);
        numQuestions++;
    }

    function makeAnswer(uint questionId, string memory text) public
    {
        auxAnswer.id = questions[questionId].answers.length;
        auxAnswer.author = msg.sender;
        auxAnswer.text = text;
        questions[questionId].answers.push(auxAnswer);
    }

    function has(address[] memory array, address value) pure private returns(int)
    {
        for (uint i = 0; i < array.length; ++i)
        {
            if (array[i] == value)
                return int(i);
        }
        return -1;
    }

    function remove(address[] storage array, address value) private
    {
        int index = has(array, value);
        if (index != -1)
        {
            array[uint(index)] = array[array.length - 1];
            array.pop();
        }
    }

    function doUpvoteQ(uint questionId) public
    {   
        require(has(questions[questionId].upVoters, msg.sender) == -1, "You already upvoted this question");
        remove(questions[questionId].downVoters, msg.sender);
        questions[questionId].upVoters.push(msg.sender);
    }

    function doDownvoteQ(uint questionId) public
    {
        require(has(questions[questionId].downVoters, msg.sender) == -1, "You already downvoted this question");
        remove(questions[questionId].upVoters, msg.sender);
        questions[questionId].downVoters.push(msg.sender);
    }

    function doUpvoteA(uint questionId, uint answerId) public
    {
        require(has(questions[questionId].answers[answerId].upVoters, msg.sender) == -1, "You already upvoted this answer");
        remove(questions[questionId].answers[answerId].downVoters, msg.sender);
        questions[questionId].answers[answerId].upVoters.push(msg.sender);
    }

    function doDownvoteA(uint questionId, uint answerId) public
    {
        require(has(questions[questionId].answers[answerId].downVoters, msg.sender) == -1, "You already downvoted this answer");
        remove(questions[questionId].answers[answerId].upVoters, msg.sender);
        questions[questionId].answers[answerId].downVoters.push(msg.sender);
    }

    function getReputationQ(uint questionId) view public returns(int)
    {
        return int(questions[questionId].upVoters.length) - int(questions[questionId].downVoters.length);
    }

    function getReputationA(uint questionId, uint answerId) view public returns(int)
    {
        return int(questions[questionId].answers[answerId].upVoters.length) - int(questions[questionId].answers[answerId].downVoters.length);
    }
    
    function getQuestions() public view returns(Pack[] memory)
    {
        Pack[] memory packs = new Pack[](questions.length);
        for (uint i = 0; i < questions.length; ++i)
        {
            packs[i].id = questions[i].id;
            packs[i].text = questions[i].text;
            packs[i].repupation = getReputationQ(questions[i].id);
        }
        return packs;
    }

    function getQuestion(uint questionId) public view returns(Question memory)
    {
        return questions[questionId];
    }

    function show() public view returns(uint[] memory, string[] memory)
    {   
        uint[] memory questionId = new uint[](questions.length);
        string[] memory questionText = new string[](questions.length);
        for (uint i = 0; i < questions.length; ++i)
        {
            questionId[i] = questions[i].id;
            questionText[i] = questions[i].text;
        }
        return (questionId, questionText);
    }
}