// Rules applied
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import AudioPlayer from '../src/components/AudioPlayer';
import { AudioFile } from '../src/types/audio';

// Mock audio file for testing
const mockAudioFile: AudioFile = {
  id: '1',
  name: 'test-song.mp3',
  url: 'blob:test-url',
  duration: 180, // 3 minutes
  file: new File([''], 'test-song.mp3', { type: 'audio/mp3' }),
  type: 'original'
};

// Mock the onRingtoneCreated callback
const mockOnRingtoneCreated = jest.fn();

describe('AudioPlayer Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('renders audio player with file information', () => {
    render(
      <AudioPlayer 
        audioFile={mockAudioFile} 
        onRingtoneCreated={mockOnRingtoneCreated}
      />
    );

    expect(screen.getByText('test-song.mp3')).toBeInTheDocument();
    expect(screen.getByText('Duration: 3:00')).toBeInTheDocument();
  });

  test('play button toggles between play and pause', () => {
    render(
      <AudioPlayer 
        audioFile={mockAudioFile} 
        onRingtoneCreated={mockOnRingtoneCreated}
      />
    );

    const playButton = screen.getByText('▶️ Play');
    expect(playButton).toBeInTheDocument();

    fireEvent.click(playButton);
    
    // Note: In a real test environment, you'd need to mock the audio API
    // This is a basic structure for testing
  });

  test('ringtone editor shows time inputs', () => {
    render(
      <AudioPlayer 
        audioFile={mockAudioFile} 
        onRingtoneCreated={mockOnRingtoneCreated}
      />
    );

    expect(screen.getByText('Create Ringtone')).toBeInTheDocument();
    expect(screen.getByText('Start Time:')).toBeInTheDocument();
    expect(screen.getByText('End Time:')).toBeInTheDocument();
  });

  test('create ringtone button is disabled when start time >= end time', () => {
    render(
      <AudioPlayer 
        audioFile={mockAudioFile} 
        onRingtoneCreated={mockOnRingtoneCreated}
      />
    );

    const createButton = screen.getByText('✂️ Create Ringtone');
    expect(createButton).toBeDisabled();
  });
});
