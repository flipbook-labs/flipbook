import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type FeatureItem = {
	title: string;
	description: JSX.Element;
};

const FeatureList: FeatureItem[] = [
	{
		title: 'Isolate your UI',
		description: (
			<>
				With flipbook you can isolate distinct parts of your game's UI to hammer
				out edge cases and complex states without having to run through the
				whole UI
			</>
		),
	},
	{
		title: 'Controls',
		description: (
			<>
				Set custom controls that your stories can respond to while iterating to
				quickly toggle states and provide custom input without changing the
				story
			</>
		),
	},
	{
		title: 'Support for Hoarcekat',
		description: (
			<>
				Bring your existing stories from Hoarcekat over to flipbook by adding a
				Storybook to set them up.
			</>
		),
	},
];

function Feature({ title, description }: FeatureItem) {
	return (
		<div className={clsx('col col--4')}>
			<div className="text--center padding-horiz--md">
				<Heading as="h3">{title}</Heading>
				<p>{description}</p>
			</div>
		</div>
	);
}

export default function HomepageFeatures(): JSX.Element {
	return (
		<section className={styles.features}>
			<div className="container">
				<div className="row">
					{FeatureList.map((props, idx) => (
						<Feature key={idx} {...props} />
					))}
				</div>
			</div>
		</section>
	);
}
