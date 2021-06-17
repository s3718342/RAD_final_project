# From https://stackoverflow.com/a/36229316/11317566
def true?(obj)
  obj.to_s.downcase == "true"
end

questions = JSON.parse(File.read('quiz.json'))

questions.each do |question|
  q = Question.create!(
    id: question["id"], 
    question: question["question"], 
    explanation: question["explanation"], 
    category: question["category"], 
    difficulty: question["difficulty"]
  )
  
  question["answers"].each do |key, value|
    if(value)
      q.answers.create!(description: value, correct: true?(question["correct_answers"]["#{key}_correct"]))
    end
  end
end
