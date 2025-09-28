# 🤖 AI Voice Story Mental Health Assessment

A FastAPI-powered application that generates unique mental health stories using OpenAI and provides voice narration for assessment purposes.

## ✨ Features

- **🎲 Dynamic Story Generation** - Each click generates a new, unique story using OpenAI
- **🎙️ Voice Narration** - Text-to-speech with customizable speed and volume
- **📊 Mental Health Assessment** - AI-powered analysis of responses
- **🎯 Multiple Story Types** - Pregnancy, Postpartum, and General mental health stories
- **📱 Responsive Design** - Works on desktop and mobile devices
- **🔒 Environment Variables** - Secure API key management

## 🚀 Quick Start

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Set Up Environment Variables
Create a `.env` file in the project root:
```env
OPENAI_API_KEY=your_openai_api_key_here
```

### 3. Run the Server
```bash
python run_server.py
```

### 4. Open in Browser
Navigate to: `http://localhost:8000`

## 🛠️ API Endpoints

### `POST /generate-story`
Generate a new story with questions
```json
{
    "story_type": "pregnancy",
    "difficulty_level": "medium",
    "language": "english"
}
```

### `POST /assess-mental-health`
Analyze assessment responses
```json
{
    "answers": [1, 2, 3, 4, 1],
    "story_id": "story_1234"
}
```

### `GET /story-types`
Get available story types

### `GET /health`
Health check endpoint

## 📖 How It Works

1. **Story Generation**: Uses OpenAI GPT-3.5-turbo to create realistic, empathetic stories
2. **Voice Narration**: Browser's built-in text-to-speech for audio playback
3. **Assessment**: AI analyzes responses to provide mental health insights
4. **Personalization**: Each story is unique and tailored to the selected type

## 🎯 Story Types

### Pregnancy Stories
- Work stress and motherhood anxiety
- Body image changes and self-doubt
- Social isolation and relationship changes
- Financial stress and future worries

### Postpartum Stories
- Sleep deprivation and overwhelming responsibilities
- Baby bonding and maternal confidence
- Social isolation and identity loss
- Health anxiety and support needs

### General Mental Health
- Work-life balance challenges
- Social anxiety and relationships
- Grief and loss experiences
- Financial stress and uncertainty

## 🔧 Configuration

### Environment Variables
- `OPENAI_API_KEY`: Your OpenAI API key (required)

### Story Customization
- Modify `STORY_TEMPLATES` in `main.py` to add new scenarios
- Update `QUESTION_TEMPLATES` for different assessment questions
- Adjust AI prompts for different story styles

## 📱 Usage

1. **Select Story Type**: Choose from pregnancy, postpartum, or general
2. **Generate Story**: Click "Generate New Story" for a unique AI story
3. **Listen**: Use voice controls to hear the story
4. **Answer Questions**: Respond to assessment questions
5. **Get Results**: Receive personalized mental health insights

## 🎨 Customization

### Adding New Story Types
```python
STORY_TEMPLATES["new_type"] = [
    "Your new scenario descriptions here"
]
```

### Modifying Questions
```python
QUESTION_TEMPLATES.append({
    "question": "Your new question about {character_name}",
    "options": ["Option 1", "Option 2", "Option 3", "Option 4"]
})
```

## 🔒 Security

- API keys stored in environment variables
- CORS enabled for cross-origin requests
- Input validation and error handling
- No sensitive data stored locally

## 🐛 Troubleshooting

### Common Issues

1. **OpenAI API Key Error**
   - Ensure `.env` file exists with valid API key
   - Check API key has sufficient credits

2. **Voice Not Working**
   - Ensure browser supports Web Speech API
   - Check browser permissions for audio

3. **Server Won't Start**
   - Check if port 8000 is available
   - Install all dependencies with `pip install -r requirements.txt`

## 📊 Assessment Scoring

- **Low Risk (0-30%)**: Good mental health awareness
- **Medium Risk (31-60%)**: Some concerns, needs monitoring
- **High Risk (61-100%)**: Significant concerns, needs intervention

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Check the troubleshooting section
- Review the API documentation
- Open an issue on GitHub

## 🔮 Future Enhancements

- [ ] Multiple language support
- [ ] Advanced AI models (GPT-4)
- [ ] User authentication and history
- [ ] Mobile app version
- [ ] Integration with healthcare systems
- [ ] Real-time collaboration features
