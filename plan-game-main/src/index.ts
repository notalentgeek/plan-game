import Phaser from 'phaser';

class Card extends Phaser.GameObjects.Image {
  constructor(scene: Phaser.Scene, x: number, y: number, texture: string) {
    super(scene, x, y, texture);
    scene.add.existing(this);
    this.setInteractive();
  }
}

class GameScene extends Phaser.Scene {
  private cards: Card[] = [];
  private selectedCard: Card | null = null;

  constructor() {
    super({ key: 'GameScene' });
  }

  preload() {
    // Load card assets (replace with your card images)
    this.load.image('card1', 'assets/card1.png');
    this.load.image('card2', 'assets/card2.png');
    this.load.image('card3', 'assets/card3.png');
    this.load.image('card4', 'assets/card4.png');
    this.load.image('card5', 'assets/card5.png');
  }

  create() {
    // Set up the fan arrangement of cards
    const screenWidth = this.sys.game.config.width as number;
    const screenHeight = this.sys.game.config.height as number;
    const cardSpacing = 50; // Horizontal spacing between cards
    const fanAngle = 20; // Angle of the fan

    const cardTextures = ['card1', 'card2', 'card3', 'card4', 'card5'];
    const startX = (screenWidth - (cardTextures.length - 1) * cardSpacing) / 2;
    const startY = screenHeight - 100; // Position cards near the bottom

    cardTextures.forEach((texture, index) => {
      const card = new Card(this, startX + index * cardSpacing, startY, texture);
      card.setOrigin(0.5, 1); // Set origin to bottom center for fan effect
      card.angle = -fanAngle / 2 + (fanAngle / (cardTextures.length - 1)) * index; // Fan angle
      this.cards.push(card);

      // Enable drag and drop for cards
      this.input.setDraggable(card);
      card.on('dragstart', () => this.onCardDragStart(card));
      card.on('drag', (pointer: Phaser.Input.Pointer, dragX: number, dragY: number) =>
        this.onCardDrag(card, dragX, dragY)
      );
      card.on('dragend', () => this.onCardDragEnd(card));
    });
  }

  private onCardDragStart(card: Card) {
    this.selectedCard = card;
    card.setDepth(1); // Bring the selected card to the front
  }

  private onCardDrag(card: Card, dragX: number, dragY: number) {
    card.x = dragX;
    card.y = dragY;
  }

  private onCardDragEnd(card: Card) {
    const screenWidth = this.sys.game.config.width as number;
    const screenHeight = this.sys.game.config.height as number;

    // Snap the card to the center of the screen if dropped near the center
    if (card.x > screenWidth / 2 - 100 && card.x < screenWidth / 2 + 100 &&
      card.y > screenHeight / 2 - 100 && card.y < screenHeight / 2 + 100) {
      card.x = screenWidth / 2;
      card.y = screenHeight / 2;
      card.angle = 0; // Reset angle
    } else {
      // Return the card to its original position in the fan
      const originalIndex = this.cards.indexOf(card);
      const startX = (screenWidth - (this.cards.length - 1) * 50) / 2;
      const startY = screenHeight - 100;
      card.x = startX + originalIndex * 50;
      card.y = startY;
      card.angle = -10 + (20 / (this.cards.length - 1)) * originalIndex;
    }

    card.setDepth(0); // Reset depth
    this.selectedCard = null;
  }
}

const config: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,
  width: 375,  // Common smartphone resolution width
  height: 667, // Common smartphone resolution height
  scale: {
    autoCenter: Phaser.Scale.CENTER_BOTH,
  },
  scene: [GameScene],
};

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const game = new Phaser.Game(config);

