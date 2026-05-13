package {{package_name}}

import (
	"context"
	"fmt"

	"github.com/sirupsen/logrus"
)

// Service provides {{package_description}}
type Service struct {
	logger *logrus.Logger
}

// NewService creates a new Service instance
func NewService(logger *logrus.Logger) *Service {
	return &Service{
		logger: logger,
	}
}

// Process processes the input and returns a result
func (s *Service) Process(ctx context.Context, input string) (string, error) {
	s.logger.WithFields(logrus.Fields{
		"input": input,
	}).Info("Processing input")

	select {
	case <-ctx.Done():
		return "", ctx.Err()
	default:
		// Your business logic here
		result := fmt.Sprintf("Processed: %s", input)
		
		s.logger.Info("Successfully processed input")
		return result, nil
	}
}

// MultiplyByTwo multiplies the input by 2
func (s *Service) MultiplyByTwo(value int) int {
	s.logger.WithField("value", value).Debug("Multiplying by 2")
	return value * 2
}
