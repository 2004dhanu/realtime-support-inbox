# Reviewer Rubric

Score each category from 0 to 5 and apply the weight.

- Codebase comprehension: 20%
- WebSocket correctness: 25%
- API integration quality: 20%
- Framework flexibility: 15%
- Adaptability to change: 10%
- Communication quality: 10%

**Notes for Reviewers**
- Validate reconnect/backoff behavior with manual disconnects.
- Check that realtime events are deduplicated and ordered.
- Look for clean separation between UI and WebSocket logic.
- Verify change request implementation against the pack.
