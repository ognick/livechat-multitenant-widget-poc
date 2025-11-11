# LiveChat User Info POC

## Overview

This project demonstrates how to create a **LiveChat Agent App Widget** that securely retrieves private user data in a multi-tenant environment.

## Key Features

- **Agent App Widget Integration** - Custom widget embedded in LiveChat agent interface
- **Multi-tenant Support** - Works with multi-license LiveChat installations
- **Secure Data Access** - Agents can only access data for users they are actively chatting with
- **OAuth Authentication** - Uses LiveChat OAuth flow for secure agent authentication
- **Session Management** - Implements session tokens with automatic expiration handling

## How It Works

1. Agent opens a chat with a customer in LiveChat
2. Widget displays customer's Chat ID and Entity ID
3. Agent clicks "Get User Data" button
4. System authenticates the agent via LiveChat OAuth
5. Backend verifies agent has access to the specific chat
6. Private user data is displayed in a popup window
7. Agent can only see data for customers they have active chats with

## Security Model

- Each agent must authenticate through LiveChat OAuth
- Session tokens are stored in localStorage with expiration
- Backend validates that agent has permission to access specific chat data
- Cross-origin communication is restricted to authorized domains

## ⚠️ Important Notice

**This is a proof-of-concept demonstration only.**

**DO NOT use this code in production environments.**

This project is intended to showcase the approach and architecture for secure multi-tenant agent data access. Production implementation would require:

- Comprehensive security audit
- Proper error handling and logging
- Rate limiting and abuse prevention
- Production-grade session management
- Compliance with data protection regulations
- Thorough testing and monitoring
