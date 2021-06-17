module QuestionsHelper
  
  def generateHistory(score, size)
    {time: DateTime.current.to_s, score: score, num_questions: size}
  end
  
end
